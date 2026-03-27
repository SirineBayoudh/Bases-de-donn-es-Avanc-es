# =========================================
# TP2 - Bases de Données
# Exercice 4 - Dépendances fonctionnelles et BCNF
# Auteur : Sirine Bayoudh
# =========================================

import itertools


# -------------------------------------------------
# 1. Afficher les dépendances fonctionnelles
# -------------------------------------------------
def printDependencies(F: "list of dependencies"):
    for alpha, beta in F:
        print("\t", alpha, "--> ", beta)


# -------------------------------------------------
# 2. Afficher les relations
# -------------------------------------------------
def printRelations(T: "list of relations"):
    for R in T:
        print("\t", R)


# -------------------------------------------------
# 3. Ensemble des parties (power set)
#    Remarque : on renvoie tous les sous-ensembles
#    non vides, comme dans l'énoncé.
# -------------------------------------------------
def powerSet(inputset: "set"):
    result = []
    elems = list(inputset)
    for r in range(1, len(inputset) + 1):
        result += list(map(set, itertools.combinations(elems, r)))
    return result


# -------------------------------------------------
# 4. Fermeture d'un ensemble d'attributs K par F
# -------------------------------------------------
def computeAttributeClosure(F: "list of dependencies", K: "set"):
    K_plus = set(K)
    changed = True

    while changed:
        changed = False
        for alpha, beta in F:
            if alpha.issubset(K_plus) and not beta.issubset(K_plus):
                K_plus.update(beta)
                changed = True

    return K_plus


# -------------------------------------------------
# 5. Fermeture de F (F+)
#    On construit toutes les DF alpha -> beta
#    déductibles sur l'univers des attributs.
# -------------------------------------------------
def computeDependenciesClosure(F: "list of dependencies"):
    universe = set()
    for alpha, beta in F:
        universe.update(alpha)
        universe.update(beta)

    F_plus = []
    subsets = [set()] + powerSet(universe)

    for alpha in subsets:
        alpha_plus = computeAttributeClosure(F, alpha)
        for beta in subsets:
            if beta.issubset(alpha_plus):
                F_plus.append([set(alpha), set(beta)])

    return F_plus


# -------------------------------------------------
# 6. Vérifier si alpha détermine fonctionnellement beta
# -------------------------------------------------
def isDependency(F: "list of dependencies", alpha: "set", beta: "set"):
    return beta.issubset(computeAttributeClosure(F, alpha))


# -------------------------------------------------
# 7. Vérifier si K est une super-clé de R
# -------------------------------------------------
def isSuperKey(F: "list of dependencies", R: "set", K: "set"):
    return R.issubset(computeAttributeClosure(F, K))


# -------------------------------------------------
# 8. Vérifier si K est une clé candidate de R
#    - K doit être une super-clé
#    - aucun sous-ensemble propre de K ne doit être super-clé
# -------------------------------------------------
def isCandidateKey(F: "list of dependencies", R: "set", K: "set"):
    if not isSuperKey(F, R, K):
        return False

    for A in list(K):
        K1 = set(K)
        K1.discard(A)
        if isSuperKey(F, R, K1):
            return False

    return True


# -------------------------------------------------
# 9. Calculer toutes les clés candidates
# -------------------------------------------------
def computeAllCandidateKeys(F: "list of dependencies", R: "set"):
    result = []
    for K in powerSet(R):
        if isCandidateKey(F, R, K):
            result.append(K)
    return result


# -------------------------------------------------
# 10. Calculer toutes les super-clés
# -------------------------------------------------
def computeAllSuperKeys(F: "list of dependencies", R: "set"):
    result = []
    for K in powerSet(R):
        if isSuperKey(F, R, K):
            result.append(K)
    return result


# -------------------------------------------------
# 11. Retourner une clé candidate
#    Stratégie : partir de R puis supprimer les
#    attributs inutiles tant que possible.
# -------------------------------------------------
def computeOneCandidateKey(F: "list of dependencies", R: "set"):
    K = set(R)

    changed = True
    while changed:
        changed = False
        for A in list(K):
            test = K.difference({A})
            if isSuperKey(F, R, test):
                K = test
                changed = True
                break

    return K


# -------------------------------------------------
# Utilitaire : projection des DF sur une relation R
# -------------------------------------------------
def projectDependencies(F: "list of dependencies", R: "set"):
    proj = []
    subsets = [set()] + powerSet(R)

    for alpha in subsets:
        alpha_plus = computeAttributeClosure(F, alpha).intersection(R)
        for beta in subsets:
            if beta and beta.issubset(alpha_plus):
                dep = [set(alpha), set(beta)]
                if dep not in proj:
                    proj.append(dep)

    return proj


# -------------------------------------------------
# 12. Vérifier si une relation R est en BCNF
#    Une relation est en BCNF si, pour toute DF
#    non triviale alpha -> beta valable sur R,
#    alpha est une super-clé de R.
# -------------------------------------------------
def isBCNFRelation(F: "list of dependencies", R: "set"):
    proj = projectDependencies(F, R)

    for alpha, beta in proj:
        # ignorer les dépendances triviales
        if beta.issubset(alpha):
            continue

        # si alpha -> beta non triviale et alpha n'est pas super-clé => violation
        if not isSuperKey(F, R, alpha):
            return False, [alpha, beta]

    return True, [set(), set()]


# -------------------------------------------------
# 13. Vérifier si un schéma T est en BCNF
# -------------------------------------------------
def isBCNFRelations(F: "list of dependencies", T: "list of relations"):
    for R in T:
        ok, witness = isBCNFRelation(F, R)
        if not ok:
            return False, R, witness
    return True, set(), [set(), set()]


# -------------------------------------------------
# 14. Décomposition BCNF
#    Algorithme itératif :
#    - trouver une relation non BCNF
#    - la décomposer selon alpha -> beta
#      en R1 = alpha ∪ beta
#      et R2 = R - (beta - alpha)
# -------------------------------------------------
def computeBCNFDecomposition(F: "list of dependencies", T: "list of relations"):
    OUT = list(T)

    changed = True
    while changed:
        changed = False

        for R in list(OUT):
            ok, witness = isBCNFRelation(F, R)

            if not ok:
                alpha, beta = witness
                R1 = alpha.union(beta)
                R2 = R.difference(beta.difference(alpha))

                OUT.remove(R)

                if R1 not in OUT:
                    OUT.append(R1)
                if R2 not in OUT:
                    OUT.append(R2)

                changed = True
                break

    return OUT


# -------------------------------------------------
# Exemple d'utilisation
# -------------------------------------------------
if __name__ == "__main__":
    myrelations = [
        {'A', 'B', 'C', 'G', 'H', 'I'},
        {'X', 'Y'}
    ]

    mydependencies = [
        [{'A'}, {'B'}],            # A -> B
        [{'A'}, {'C'}],            # A -> C
        [{'C', 'G'}, {'H'}],       # CG -> H
        [{'C', 'G'}, {'I'}],       # CG -> I
        [{'B'}, {'H'}]             # B -> H
    ]

    print("Dépendances :")
    printDependencies(mydependencies)

    print("\nRelations :")
    printRelations(myrelations)

    R = {'A', 'B', 'C', 'G', 'H', 'I'}
    K = {'A', 'G'}

    print("\nFermeture de", K, ":", computeAttributeClosure(mydependencies, K))
    print("Super-clés :", computeAllSuperKeys(mydependencies, R))
    print("Clés candidates :", computeAllCandidateKeys(mydependencies, R))
    print("Une clé candidate :", computeOneCandidateKey(mydependencies, R))
    print("BCNF sur R :", isBCNFRelation(mydependencies, R))
    print("Décomposition BCNF :", computeBCNFDecomposition(mydependencies, [R]))
