## testing my functions
start
    num: zar <- rastgele(1, 6);
    num: big <- rastgele(10, 20) * 2 + rastgele(-5, zar);
    text: name <- "Big Man";
    text: loud <- KOCAMAN(name), quiet <- kucuk(name);
    loud <- KOCAMAN(kucuk("MiXeD"));

    when (rastgele(0, 1) = 1 and KOCAMAN(name) <> name) then
        show(KOCAMAN("heads"));
    otherwise
        show(kucuk("TAILS"));
    endwhen
finish
