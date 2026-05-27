def build_indices(n: int) -> list[int]:
    result = [0]

    left = 1
    right = n - 1

    take_left = True

    while left <= right:
        if take_left:
            result.append(left)
            left += 1
        else:
            result.append(right)
            right -= 1

        take_left = not take_left

    return result


def main():
    for n in [4, 5, 6, 7, 8]:
        indices = build_indices(n)
        print(indices)


if __name__ == "__main__":
    main()
