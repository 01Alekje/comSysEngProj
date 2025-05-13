def eliminate(A):
    N = len(A)

    for k in range(N):
        pivot = A[k][k]

        # Normalisera pivotraden och eliminera samtidigt
        for j in range(k + 1, N):
            A[k][j] = A[k][j] / pivot  # normalisera pivotraden

            for i in range(k + 1, N):
                A[i][j] = A[i][j] - A[i][k] * A[k][j]

        A[k][k] = 1.0

        # Nollställ kolumn under pivot
        for i in range(k + 1, N):
            A[i][k] = 0.0

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
