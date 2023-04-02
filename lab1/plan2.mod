/* OPTIMIZATION METHODS
ex 1.4.2 - Restricted Schedule Problem
Author: Janusz Witkowski 254663
*/

set Groups;     # Groups of courses
set Courses;    # Different courses
set Days;       # Days in school week

param Rates{Groups, Courses}, integer, >= 0, <= 10;     # Groups of courses are rated
param OnDays{Groups, Courses}, integer, >= 1, <= 5;     # On which day of the week does a course group take place
param DaysToInts{Days}, integer, >= 1, <= 5;            # Helper param
param Begins{Groups, Courses}, integer, >= 1, <= 24*2;  # Starting hours of courses [in half-hours]
param Ends{Groups, Courses}, integer, >= 1, <= 24*2;    # Ending hours of courses [in half-hours]

var Enroll{Groups, Courses}, binary;       # Main objective - a chart of course group the student enrolled to
var TimeTable{Days, {1..48}}, binary;      # Which half-hours are taken by courses and activities (does not allow for overlaps)
var Sports{{1..3}}, binary;                # Which sport group does the student want to attend to


# We want to enroll to best possible course groups
maximize satisfaction: sum{g in Groups, c in Courses}(Enroll[g, c] * Rates[g, c]);

# Constraint - You should have time for at least one sports activity
s.t. at_least_one_sport:
    sum{s in {1..3}}(Sports[s]) >= 1;

# Definition - A Time Table consists of half-hours taken by Student's activities
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

# Constraint - You must enroll for exactly one group for each course
s.t. one_group_per_course{c in Courses}:
    (sum{g in Groups}(Enroll[g, c])) = 1;

# Constraint - You don't want to have more than four hours (eigth half-hours) of obligatory courses per day
s.t. max_four_hours_per_day{d in Days}:
    (sum{h in {1..48}}(TimeTable[d, h])) <= 4*2;

# Constraint - Find at least 1 hours (2 half-hours) between 12:00 and 14:00 to get a snack
s.t. lunch_break{d in Days}:
    sum{h in {12*2..((14*2)-1)}}(TimeTable[d, h]) <= 1*2;

# [1.4.2] Constraint - We don't want to have any obligatory courses on Wed & Fri
s.t. no_plans_for_sr_pt{di in {3,5}}:
    sum{g in Groups, c in Courses}(
        Enroll[g, c] * (if OnDays[g, c] = di then 1 else 0)
    ) = 0;

# [1.4.2] Constraint - We don't want to enroll for not-so pleasing course group
s.t. no_course_with_rating_below_five:
    sum{g in Groups, c in Courses}(
        Enroll[g, c] * (if Rates[g, c] < 5 then 1 else 0)
    ) = 0;

solve;


printf "\nFUNKCJA CELU: %d\n", satisfaction;
printf "\n";

printf "ZAPISANO NA KURSY\n";
for{c in Courses, g in Groups}{
    printf (if Enroll[g, c] > 0 then "%s: %s [(%s) %f-%f] <%s>\n" else ""), c, g, OnDays[g, c], Begins[g, c]/2, Ends[g, c]/2, Rates[g, c];
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

param Rates: Algebra Analiza Fizyka Mineraly Organiczna :=
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

param Begins: Algebra Analiza Fizyka Mineraly Organiczna :=
    I 26 26 16 16 18
    II 20 20 20 16 21
    III 20 22 30 26 22
    IV 22 16 34 26 26;

param Ends: Algebra Analiza Fizyka Mineraly Organiczna :=
    I 30 30 22 20 21
    II 24 24 26 20 24
    III 24 26 36 30 25
    IV 26 20 40 30 29;


end;
# glpsol --model plan2.mod --output out/plan2.txt | tee plan2.log
