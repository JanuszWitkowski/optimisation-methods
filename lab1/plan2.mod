set Groups;
set Courses;
set Days;

param Grades{Groups, Courses}, integer, >= 0, <= 10;
param OnDays{Groups, Courses}, integer, >= 1, <= 5;
param DaysToInts{Days}, integer, >= 1, <= 5;
param Begins{Groups, Courses}, integer, >= 1, <= 48;
param Ends{Groups, Courses}, integer, >= 1, <= 48;

var Enroll{Groups, Courses}, integer, >= 0, <= 1;
var TimeTable{Days, {1..48}}, integer, >= 0, <= 1;
var Sports{{1..3}}, integer, >= 0, <= 1;


maximize satisfaction: sum{g in Groups, c in Courses}(Enroll[g, c] * Grades[g, c]);

s.t. at_least_one_sport:
    sum{s in {1..3}}(Sports[s]) >= 1;

s.t. def_time_table{d in Days, h in {1..48}}:
    TimeTable[d, h] = sum{g in Groups, c in Courses}(
        Enroll[g, c] * (if OnDays[g, c] = DaysToInts[d] then 1 else 0) * (
            if h < Begins[g, c] then 0 else
            if h >= Ends[g, c] then 0 else 1
        )
    ) + Sports[1] * (
        if DaysToInts[d] != 1 then 0 else
        if h < 13*2 then 0 else
        if h >= 15*2 then 0 else 1
    ) + Sports[2] * (
        if DaysToInts[d] != 3 then 0 else
        if h < 11*2 then 0 else
        if h >= 13*2 then 0 else 1
    ) + Sports[3] * (
        if DaysToInts[d] != 3 then 0 else
        if h < 13*2 then 0 else
        if h >= 15*2 then 0 else 1
    );

# MODYFIKACJE 4.2
s.t. one_group_per_course_and_grades_over_five{c in Courses}:
    (sum{g in Groups}(Enroll[g, c])) = 1;

s.t. max_four_hours_per_day{d in Days}:
    (sum{h in {1..48}}(TimeTable[d, h])) <= 4*2;

s.t. lunch_break{d in Days}:
    sum{h in {12*2..((14*2)-1)}}(TimeTable[d, h]) <= 1*2;

solve;


printf "\nFUNKCJA CELU: %d\n", satisfaction;
printf "\n";

printf "ZAPISANO NA KURSY\n";
for{c in Courses, g in Groups}{
    printf (if Enroll[g, c] > 0 then "%s: %s [(%s) %f-%f] <%s>\n" else ""), c, g, OnDays[g, c], Begins[g, c]/2, Ends[g, c]/2, Grades[g, c];
}
printf "\n";

printf "SPORT\n";
printf "Pn 13-15: %d\n", Sports[1];
printf "Sr 11-13: %d\n", Sports[2];
printf "Sr 13-15: %d\n", Sports[3];
printf "\n";


data;
set Groups := 'I' 'II' 'III' 'IV';
set Courses := 'Algebra' 'Analiza' 'Fizyka' 'Mineraly' 'Organiczna';
set Days := 'Pn' 'Wt' 'Sr' 'Cz' 'Pt';

param Grades: Algebra Analiza Fizyka Mineraly Organiczna :=
    I 5 4 3 10 0
    II 4 4 5 10 5
    III 10 5 7 7 3
    IV 5 6 8 5 4;

param OnDays: Algebra Analiza Fizyka Mineraly Organiczna :=
    I 1 1 2 1 1
    II 2 2 2 1 1
    III 3 3 4 4 5
    IV 3 4 4 5 5;

param DaysToInts :=
    Pn 1
    Wt 2
    Sr 3
    Cz 4
    Pt 5;

# MODYFIKACJE DLA ZADANIA 4.2
param Begins: Algebra Analiza Fizyka Mineraly Organiczna :=
    I 26 24 24 16 24
    II 24 24 20 16 21
    III 24 24 30 26 24
    IV 24 16 34 24 24;

param Ends: Algebra Analiza Fizyka Mineraly Organiczna :=
    I 30 28 28 20 28
    II 28 28 26 20 24
    III 28 28 36 30 28
    IV 28 20 40 28 28;


end;
