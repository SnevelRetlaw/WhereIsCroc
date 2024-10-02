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

myFunction=function(moveInfo,readings,positions,edges,probs) {
  # Calculate transition matrix if it is not in memory

  # (check if a tourist has been eaten)

  # calculate probabilies for croc being in each waterhole. This is the emmission matrix
  probabilityVector = generateProbabilityMatrix(readings, probs)

  # (Exclude waterholes where tourists are and ranger)

  # multiply transition matrix with emission matrix

  # determine move from resulting vector.

  moveInfo$moves=c(sample(getOptions(positions[3],edges),1),0)
  return(moveInfo)
}


generateProbabilityMatrix=function(readings, probs){
  #loop through matrix of mean and stdev
  # calculate probability for each measurement of a waterhole using gaussian distribution

  # compute average of the three probabilities to get probability of the watehole

  # add to list.

}
