




/*func filterGreaterThanValue(value: Int, numbers: [Int]) -> [Int]{
 var filteredSetOfNumbers = [Int]()
 for num in numbers{
 if num > value {
 filteredSetOfNumbers.append(num)
 }
 }
 return filteredSetOfNumbers
 }*/

func filterWithPredicateClosure(closure: (Int) -> Bool, numbers: [Int]) -> [Int]{//closure here is function itself
    var filteredSetOfNumbers = [Int]()
    for num in numbers{
        //perform some condition check here
        if closure(num){//when condition of closure is true, if condition is run
            filteredSetOfNumbers.append(num)
        }
    }
    return filteredSetOfNumbers
}

func divisibleByFive(value: Int) -> Bool{
    return value % 5 == 0
}

func greaterThanThree(value: Int) -> Bool{
    return value > 3
}

var filteredList = filterWithPredicateClosure(closure: divisibleByFive, numbers: [20, 30, 40, 1, 2, 9, 15])
// var filteredList = filterWithPredicateClosure(closure: greaterThanThree, numbers: [1, 3, 5, 10])

/* var filteredList = filterWithPredicateClosure(closure: { (num) -> Bool in
 return num < 20
 }, numbers: [1, 2, 3, 4, 5, 10])*/

//var filteredList = filterGreaterThanValue(value: 3, numbers: [1, 2, 3, 4, 5, 10])

