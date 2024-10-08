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
  alpha = rep(1 / N, N)
  
  #################
  
  # Calculate forward probabilities for each waterhole
  alpha = forward_step(alpha, transition_prob, emission_probs, N)
  
  # Get the waterhole with the highest probability
  moveHole = which.max(alpha)
  
  # Update moveInfo with the move to the waterhole with the highest probability and save alpha
  moveInfo$moves = moveHole
  moveInfo$mem$alpha = alpha
  return(moveInfo)
  
  ############### Walter comments / TODOs ################
  # Calculate transition matrix if it is not in memory
  
  # (check if a tourist has been eaten)
  
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
      sum_prob = sum_prob + alpha[i] * transition_prob[i,j]  # Transition part
    }
    new_alpha[j]=sum_prob * emission_probs[j]  # Emission part
  }
  
  # Normalize to avoid underflow
  new_alpha=new_alpha / sum(new_alpha)
  return(new_alpha)
}
