#!/usr/bin/python

def balance(x):
    balance = 0
    for i in range(6):
        if x % 2:
            balance = balance + 1
        else:
            balance = balance - 1
        x = int(x / 2)
    return balance

for i in range(2**6):
    print 'TO_SIGNED('+str(balance(i)).rjust(2)+',4) when unbalanced = "'+str(bin(i))[2:].rjust(6,'0')+'" else'
