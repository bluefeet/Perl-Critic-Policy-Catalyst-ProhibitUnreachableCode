{ $c->detach; }

{
    print "hi!";
    $c->detach;
}

{
    $c->detach if 1;
    print "hi!";
}

{
    $c->detach;
    sub foo { }
}
