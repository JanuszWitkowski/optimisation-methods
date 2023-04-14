#!/usr/bin/python3

def rowne_slowniki(slownik1, slownik2) -> bool:
    for key in slownik1:
        if key not in slownik2:
            return False
        if slownik1[key] != slownik2[key]:
            return False
    for key in slownik2:
        if key not in slownik1:
            return False
        if slownik1[key] != slownik2[key]:
            return False
    return True

def slownik_w_liscie(slownik, lista) -> bool:
    for element in lista:
        if rowne_slowniki(slownik, element):
            return True
    return False

def inkrementuj_klucz(slownik, klucz):
    if klucz in slownik:
        slownik[klucz] += 1
    else:
        slownik[klucz] = 1

class Node:
    def __init__(self, v, parent=None):
        # self.children = []
        self.value = v
        self.parent = parent

    def new_child(self, v):
        child = Node(v, self)
        # self.children.append(child)
        return child
    
    def tree_to_dict(self, dic=dict()):
        inkrementuj_klucz(dic, self.value)
        if self.parent == None:
            return dic
        return self.parent.tree_to_dict(dic)

def rozpatrz_nowy_podzial(lista, drzewo, pozostalo, szerokosci, szerokosc):
    if pozostalo >= szerokosc:
        drzewko = drzewo.new_child(szerokosc)
        pozostalo -= szerokosc
        # print(pozostalo)
        for s in szerokosci:
            # if pozostalo >= s:
            rozpatrz_nowy_podzial(lista, drzewko, pozostalo, szerokosci, s)
    else:
        ctr = 0
        for s in szerokosci:
            if s != szerokosc and pozostalo >= s:
                rozpatrz_nowy_podzial(lista, drzewo, pozostalo, szerokosci, s)
                ctr += 1
        if ctr == 0:
            slownik = drzewo.tree_to_dict()
            # print(slownik)
            if not slownik_w_liscie(slownik, lista):
                lista.append(slownik)
            # lista.append(drzewo.tree_to_dict())
                

szerokosci = [7,5,3]
paleta = 22
podzialy = []

for s in szerokosci:
    pozostalo = paleta
    if pozostalo >= s:
        sposoby = Node(s)
        pozostalo -= s
        # print(pozostalo)
        for sz in szerokosci:
            rozpatrz_nowy_podzial(podzialy, sposoby, pozostalo, szerokosci, sz)

print(podzialy)

