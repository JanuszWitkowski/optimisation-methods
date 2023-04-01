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


maximize satisfaction: sum{g in Groups, c in Courses}(Enroll[g, c] * Grades[g, c]);

s.t. def_time_table{d in Days, h in {1..48}}:
    TimeTable[d, h] = sum{g in Groups, c in Courses}(
        Enroll[g, c] * (if OnDays[g, c] = DaysToInts[d] then 1 else 0) * (
            if h > Ends[g, c] then 0 else
            if h < Begins[g, c] then 0 else 1
        )
    );

s.t. one_group_per_course{c in Courses}:
    (sum{g in Groups}(Enroll[g, c])) = 1;

s.t. max_four_hours_per_day{d in Days}:
    sum{g in Groups, c in Courses}(
        Enroll[g, c] *
        (if OnDays[g, c] = DaysToInts[d] then Ends[g, c] - Begins[g, c] else 0)
    ) <= 4*2;

s.t. lunch_break{d in Days}:
    sum{g in Groups, c in Courses} (
        Enroll[g, c] * (
            if OnDays[g, c] != DaysToInts[d] then 0 else (
                if Ends[g, c] <= 12 then 0 else
                if Begins[g, c] >= 14 then 0 else
                if Ends[g, c] = 13 then 1 else
                if Begins[g, c] = 13 then 1 else 2
            )
        )
    ) <= 1;

solve;


printf "\nZAPISANO NA KURSY\n";
for{c in Courses, g in Groups}{
    printf (if Enroll[g, c] > 0 then "%s: %s [(%s) %f-%f]\n" else ""), c, g, OnDays[g, c], Begins[g, c]/2, Ends[g, c]/2;
}
printf "\n";
# display TimeTable;
# display Enroll;


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
