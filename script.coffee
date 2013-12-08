fs = require 'fs'

# Config
# ---------------

# Defaults
tables = 12
maxPerTable = 8
rounds = 3
filename = 'data.csv'

# Override from command line arguments
args = process.argv.slice 2

i = 0
while i <= args.length - 1
    switch args[i]
        when "-t" then tables = args[i+1]
        when "-p" then maxPerTable = args[i+1]
        when "-f" then filename = args[i+1]
        when "-r" then rounds = args[i+1]
    i+= 2

console.log "Options : #{tables} tables of max #{maxPerTable} people and #{rounds} rounds."

# Helpers
# ---------------

# Person class
class Person
    constructor: (line) ->
        info = line.split ','
        @name = info[1]
        @dept = info[0]
        @rounds = new Array rounds

    csv: ->
        "#{@name};#{@dept};#{@rounds[0]};#{@rounds[1]};#{@rounds[2]}\n"

# True shuffling of array
shuffle = (array) ->
  for origin in [array.length-1..1]
    target = Math.floor Math.random() * (origin + 1)
    [array[origin], array[target]] = [array[target], array[origin]]
  array

# Iterate over the tables
next = (index) ->
    if index == tables - 1 then 0 else index + 1

# Get the sub-list of people for a certain table and certain round
peopleByTableByRound = (people, round, table) ->
    people.filter (p) -> p.rounds[round] == table


# Tests
# ---------------

# Define the test you want to run on a table and add them to 'canFillTable'
# so thath they must validate every time we try to sit someone at a table

tableIsFull = (table) ->
    table.length >= maxPerTable

noMoreThanXFromSameDept = (table, person, x) ->
    (item for item in table when item.dept == person.dept).length <= x - 1

noMoreThanXFromRound = (table, person, round, x) ->
    (item for item in table when item.rounds[round] == person.rounds[round]).length <= x - 1

canFillTable = (people, currentRound, runner, person) ->
    table = peopleByTableByRound people, currentRound, runner
    full = tableIsFull table
    deptOk = noMoreThanXFromSameDept table, person, 2
    prevRoundOk = if currentRound >= 1 then noMoreThanXFromRound(table, person, currentRound - 1, 2) else true
    prevPrevRoundOk = if currentRound >= 2 then noMoreThanXFromRound(table, person, currentRound - 2, 2) else true
    (not full) and deptOk and prevRoundOk and prevPrevRoundOk

# Run
# ---------------

console.log "Loading data from #{filename}"

# Load data from csv, use format 'department,name;' for every line
people = (fs.readFileSync(filename).toString().split ';').map (line) -> new Person line

console.log "Found #{people.length} people"

# Adapt the number of tables giving priority to the number of people per table
if tables * maxPerTable < people.length or tables * maxPerTable >= people.length + maxPerTable
    tables = people.length / maxPerTable
    if (Math.floor tables) < tables then tables = 1 + Math.floor tables
    console.log "Adjusting the number of table to #{tables}"

# Calculate weight for each departments
weights = {}
for person in people
    if person.dept of weights then weights[person.dept]++ else weights[person.dept] = 1

console.log "Calculating the weight of each department"
console.log weights

# Shuffle people list to get different each time
shuffle people

# Sort people by department weight and department to put the most limiting ones at the top
people.sort (p1, p2) ->
    if p1.dept == p2.dept then return 0
    if weights[p1.dept] <= weights[p2.dept] then 1 else -1

console.log "Start sitting people at tables"

runner = -1
# Iterate over rounds
for currentRound in [0..rounds - 1]

    console.log "\tRound #{currentRound + 1}"

    # Iterate over people and try ti put them at a table, if no table is possible then we consider the failure and throw and exception
    for person in people
        runner = next runner
        origin = runner
        while not canFillTable people, currentRound, runner, person
            runner = next runner
            if runner == origin then throw new Error "Tests are too strict and we can't place people"
        person.rounds[currentRound] = runner

    # Reshuffle and sort after each round (we don't sort by name so it's actually useful to get varying results)
    shuffle people
    people.sort (p1, p2) ->
        if p1.dept == p2.dept then return 0
        if weights[p1.dept] <= weights[p2.dept] then 1 else -1

# Create csv string & write
output = "name;department;round 1;round2;round3\n" + people.reduce ((s, person) -> s + person.csv()), ""
fs.writeFileSync 'out.csv', output

console.log "Result available in output.csv"
