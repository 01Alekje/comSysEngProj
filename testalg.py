def eliminate(A):
    N = len(A)
    # Loop over each pivot element
    for k in range(N):
        # Normalize pivot row elements to the right of the pivot
        pivot = A[k][k]
        for j in range(k + 1, N):
            A[k][j] = A[k][j] / pivot

            factor = A[j][k]
            for f in range(k + 1, N):
                A[j][f] -= factor * A[k][f]
            

            #A[k+1][j] -= A[k+1][k] * A[k][j]
        # Set pivot element to 1.0
        A[k][k] = 1.0
        # Eliminate entries below the pivot
        for i in range(k + 1, N):
            A[i][k] = 0.0
            #factor = A[i][k]
            #for j in range(k + 1, N):
            #    A[i][j] -= factor * A[k][j]
            #A[i][k] = 0.0
            # Zero out the lower element

# Example 4x4 matrix from assembly
matrix_4x4 = [
    [57.0, 20.0, 34.0, 59.0],
    [104.0, 19.0, 77.0, 25.0],
    [55.0, 14.0, 10.0, 43.0],
    [31.0, 41.0, 108.0, 59.0],
]

if __name__ == "__main__":
    # Make a copy to preserve original
    import copy
    A = copy.deepcopy(matrix_4x4)
    print("Original matrix:")
    for row in A:
        print(row)
    eliminate(A)
    print("\nUpper triangular matrix:")
    for row in A:
        print(row)
