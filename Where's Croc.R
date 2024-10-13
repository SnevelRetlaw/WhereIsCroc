#' @param moveInfo A list of information for the move. This has two fields. The first is a
#' vector of numbers called 'moves', where you will enter the moves you want to make. You should
#' enter two moves (so you can move to a neighboring waterhole and search). Valid moves are the
#' numbers of a neighboring or current waterhole or '0' which means you will search your current
#' waterhole for Croc. The second field is a list called
#' 'mem' that you can use to store information you want to remember from turn to turn.
#' @param readings A vector giving the salinity, phosphate and nitrogen reading from Croc sensors at his current
#' location.
#' @param positions A vector giving the positions of the two tourists (elements 1 and 2) and yourself (element 3).
#' If a tourist has just been eaten by Croc that turn, the position will be multiplied by -1.
#' If a tourist was eaten by Croc in a previous turn, then the position will be NA.
#' @param edges a two column matrix giving the edges paths between waterholes (edges) present
#' (the numbers are from and to numbers for the waterholes).
#' All edges can be crossed both ways, so are only given once.
#' @param probs a list of three matrices giving the mean and standard deviation of readings
#' for salinity, phosphate and nitrogen respectively at each waterhole.
#' @return Your function should return the first argument passed with an updated moves vector
#' and any changes to the 'mem' field you wish to access later on.

myFunction = function(moveInfo,
                      readings,
                      positions,
                      edges,
                      probs) {
  # Initialize HMM
  #################
  
  # Number of waterholes (states)
  N = 40
  
  # Initial transition matrix (assuming equal probabilities)
  transition_prob = matrix(1 / N, nrow = N, ncol = N)
  
  # Function to calculate emission probability using normal distribution
  emission_probs = generateWaterholeProb(readings, probs, N)
  
  # Initialize forward probabilities (alpha) to uniform at first step
  if (length(moveInfo$mem) == 1 || moveInfo$mem$status == 1) {
    alpha = rep(1 / N, N)
    moveInfo$mem$status = 0
  } else{
    alpha = moveInfo$mem$alpha
  }
  
  #################
  
  # Calculate forward probabilities for each waterhole
  alpha = forward_step(alpha, transition_prob, emission_probs, N)
  
  # Get the waterhole with the highest probability
  moveHole = which.max(alpha)
  
  # Find the shortest path to the waterhole with the highest probability
  path = a_star(edges, positions[3], moveHole)$path
  
  # When a tourist has been eaten
    if (!is.na(positions[1]) && positions[1] < 0) {
      path = a_star(edges, positions[3], positions[1] * -1)$path
      alpha = rep(0, N)
      alpha[positions[1] * -1] = 1
    }
    if (!is.na(positions[2]) && positions[2] < 0) {
      path = a_star(edges, positions[3], positions[2] * -1)$path
      alpha = rep(0, N)
      alpha[positions[2]* -1] = 1
    }
  
  
  # If the waterhole with the highest probability is the current waterhole, search
  # Extract move
  if (length(path) > 1) {
    nextMove = path[2]
  } else {
    # If no valid second step, stay in the current waterhole and search
    nextMove = positions[3]
  }
  
  # Update moveInfo with the move to the waterhole with the highest probability and save alpha
  moveInfo$moves = c(nextMove, 0)
  moveInfo$mem$alpha = alpha
  return(moveInfo)
  
  ############### Walter comments / TODOs ################
  
  # Calculate transition matrix if it is not in memory
  
  # (Exclude waterholes where tourists are and ranger)
}

# Function to calculate probability of each waterhole given sensor readings
generateWaterholeProb = function(readings, probs , N) {
  # loop through matrix of mean and stdev of each waterhole
  # calculate probability for each measurement of a waterhole using gaussian distribution
  
  waterhole_prob = rep(0, 40)
  
  for (i in 1:N) {
    # get mean and stdev for each measurement
    salinity = probs$salinity[i, ]
    phosphate = probs$phosphate[i, ]
    nitrogen = probs$nitrogen[i, ]
    
    # calculate probability for each measurement
    salinity_prob = dnorm(readings[1], salinity[1], salinity[2])
    phosphate_prob = dnorm(readings[2], phosphate[1], phosphate[2])
    nitrogen_prob = dnorm(readings[3], nitrogen[1], nitrogen[2])
    
    # compute average of the three probabilities to get probability of the watehole
    waterhole_prob[i] = (salinity_prob + phosphate_prob + nitrogen_prob) / 3
    
  }
  return(waterhole_prob)
  
}

# Function for the forward algorithm at each time step
forward_step = function(alpha, transition_prob, emission_probs , N) {
  new_alpha = rep(0, N)
  for (j in 1:N) {
    sum_prob = 0
    for (i in 1:N) {
      sum_prob = sum_prob + alpha[i] * transition_prob[i, j]  # Transition part
    }
    new_alpha[j] = sum_prob * emission_probs[j]  # Emission part
  }
  
  # Normalize to avoid underflow
  new_alpha = new_alpha / sum(new_alpha)
  return(new_alpha)
}

#' A-star (A*) algorithm for finding the shortest path between waterholes
#' @param edges A matrix where each row represents an edge (connection) between two waterholes (nodes)
#' @param start The start waterhole (node index)
#' @param goal The goal waterhole (node index)
#' @return A list containing the shortest distance and the path from the start to the goal waterhole
a_star = function(edges, start, goal) {
  # Extract unique waterholes (nodes)
  waterholes = unique(c(edges[, 1], edges[, 2]))
  num_waterholes = length(waterholes)
  
  # Map waterhole indices (node index starts at 1)
  node_index = function(waterhole)
    which(waterholes == waterhole)
  
  # Convert start and goal to node indices
  start_index = node_index(start)
  goal_index = node_index(goal)
  
  # Initialize distance for each waterhole to "infinity"
  distances = rep(Inf, num_waterholes)
  distances[start_index] = 0
  
  # Priority queue for nodes, using heuristic (Manhattan distance is arbitrary here)
  node_priorities = rep(Inf, num_waterholes)
  node_priorities[start_index] = 0  # Start node has a priority of 0
  
  # Keep track of the parent (for reconstructing the path)
  parent = rep(NA, num_waterholes)
  
  # Keep track of visited nodes
  visited_nodes = rep(FALSE, num_waterholes)
  
  # While there are nodes left to explore
  repeat {
    # Find the node with the lowest priority
    inspected_node_index = which.min(node_priorities)
    
    if (node_priorities[inspected_node_index] == Inf) {
      # No more nodes to visit (goal unreachable)
      return(list(distance = -1, path = NULL))
    }
    
    # If we reached the goal, reconstruct the path
    if (inspected_node_index == goal_index) {
      path = goal
      while (!is.na(parent[inspected_node_index])) {
        inspected_node_index = parent[inspected_node_index]
        path = c(waterholes[inspected_node_index], path)
      }
      return(list(distance = distances[goal_index], path = path))
    }
    
    # Mark the current node as visited
    visited_nodes[inspected_node_index] = TRUE
    
    # Remove the current node from future consideration
    node_priorities[inspected_node_index] = Inf
    
    # Get the current waterhole
    current_waterhole = waterholes[inspected_node_index]
    
    # Find neighbors (connected waterholes)
    neighbors = unique(c(edges[edges[, 1] == current_waterhole, 2], edges[edges[, 2] == current_waterhole, 1]))
    
    # For each neighboring waterhole
    for (neighbor in neighbors) {
      neighbor_index = node_index(neighbor)
      
      # Skip visited nodes
      if (visited_nodes[neighbor_index]) {
        next
      }
      
      # The new distance to the neighbor is the current distance + 1 (uniform weight)
      new_distance = distances[inspected_node_index] + 1
      
      # If this new distance is better, update distances and priorities
      if (new_distance < distances[neighbor_index]) {
        distances[neighbor_index] = new_distance
        parent[neighbor_index] = inspected_node_index
        
        # Heuristic can be simple, here it's 0 since weights are equal
        node_priorities[neighbor_index] = new_distance
      }
    }
  }
}
