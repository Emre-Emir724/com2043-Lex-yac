#* full_features.mpl
   Uses every MPL feature at least once. *#
start
    ## declarations: several names, optional starting value
    num: counter <- 0, limit <- 10, total;
    real: average <- 0.0, temperature <- 25.5;
    letter: grade <- 'A', newline <- '\n';
    flag: done <- no, ready <- yes;
    text: name <- "MPL";

    ask(total, temperature);

    ## arithmetic with precedence, parentheses, power, modulus, unary minus
    total <- (counter + limit) * (total - 5) / 2 % 7;
    average <- -temperature ^ 2 + 3.75 * -(limit - 1);

    ## when / orwhen / otherwise
    when (total > 100 and not done) then
        grade <- 'A';
        show("big total: ", total);
    orwhen (total >= 50 or average <> 0.0) then
        grade <- 'B';
    orwhen (total = 0) then
        grade <- 'C';
    otherwise
        grade <- 'F';
    endwhen

    ## while loop with a nested when
    while (counter < limit) do
        counter <- counter + 1;
        when (counter % 2 = 0) then
            show(counter);
        endwhen
    endwhile

    ## repeat-until loop
    repeat
        limit <- limit - 1;
    until (limit <= 0 or done = yes);

    show(name, grade, average);
finish
