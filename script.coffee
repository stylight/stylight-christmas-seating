fs = require 'fs'

# ---------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------

class Person
    constructor: (name, dept) ->
        @name = name
        @dept = dept
        switch dept
            when 'IT' then @weight = 16
            when 'SEO' then @weight = 16
            when 'BD' then @weight = 14
            when 'SEM' then @weight = 6
            when 'HR' then @weight = 4
            when 'QA' then  @weight = 20
            when 'CCM' then @weight = 16
            else @weight = 0
        @rounds = [-1,-1,-1]

    str: ->
        "#{@name} (#{@dept}) #{@rounds}"

    csv: ->
        "#{@name};#{@dept};#{@rounds[0]};#{@rounds[1]};#{@rounds[2]}\n"

# ---------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------

shuffle = (a) ->
  for i in [a.length-1..1]
    j = Math.floor Math.random() * (i + 1)
    [a[i], a[j]] = [a[j], a[i]]
  a

next = (index) ->
    if index == 11 then 0 else index + 1

personFromLine = (line) ->
    info = line.split ','
    new Person info[1], info[0]

peopleByTableByRound = (people, round, table) ->
    people.filter (p) -> p.rounds[round] == table

# ---------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------

tableIsFull = (table) ->
    table.length >= 8

noMoreThanXFromSameDept = (table, person, x) ->
    same = (item for item in table when item.dept == person.dept)
    same.length <= x - 1

noMoreThanXFromPreviousRound = (table, person, x) ->
    same = (item for item in table when item.rounds[round - 1] == person.rounds[round - 1])
    same.length <= x - 1

noMoreThanXFromTwoPreviousRound = (table, person, x) ->
    same = (item for item in table when item.rounds[round - 2] == person.rounds[round - 2])
    same.length <= x - 1

canFillTable = (people, round, runner, person) ->
    table = peopleByTableByRound people, round, runner
    full = tableIsFull table
    deptOk = noMoreThanXFromSameDept table, person, 2
    prevRoundOk = if round >= 1 then noMoreThanXFromPreviousRound table, person, 1 else true
    prevPrevRoundOk = if round >= 2 then noMoreThanXFromTwoPreviousRound table, person, 2 else true
    (not full) and deptOk and prevRoundOk and prevPrevRoundOk

# ---------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------

printTable = (table, id) ->
    out = "\nTable #{id} (#{table.length} people)"
    for person in table
        out += "\n - #{person.str()} "
    console.log out
    out

printTables = (people, round) ->
    runner = -1
    while runner < 11
        runner = next runner
        table = peopleByTableByRound people, round, runner
        printTable table, runner

# ---------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------

people = (fs.readFileSync('data.csv').toString().split ';').map (line) -> personFromLine line

shuffle people

people.sort (p1, p2) ->
    if p1.dept == p2.dept
        return 0
    if p1.weight <= p2.weight then 1 else -1

console.log "Found #{people.length} people to sit"

runner = -1

for round in [0..2]

    console.log "\n------------------------\nCalculating round #{round + 0}\n------------------------"

    for person in people
        runner = next runner
        while not canFillTable people, round, runner, person
            runner = next runner
        person.rounds[round] = runner

    printTables people, round
    shuffle people
    people.sort (p1, p2) ->
        if p1.dept == p2.dept
            return 0
        if p1.weight <= p2.weight then 1 else -1

output = "name;department;round 1;round2;round3\n" + people.reduce ((s, person) -> s + person.csv()), ""
fs.writeFileSync 'out.csv', output




