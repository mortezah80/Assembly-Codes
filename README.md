### Assembly Code Repository

#### CompleteNumber.asm:
This assembly program identifies whether a given input number is a perfect number, indicating "Perfect" if it meets the criteria or "Nope" otherwise. Additionally, it displays all divisors of the input number in ascending order, separated by spaces.

#### DigitAddEO.asm:
This assembly code calculates the sum of the odd and even digits of an input number. It then prints these sums in a single line, separated by a space.

#### GCC.asm:
This assembly program computes the greatest common divisor (GCD) of two input numbers using Euclid's algorithm. It then prints the resulting GCD without any additional characters.

#### LFC.asm:
This assembly program determines the least common multiple (LCM) of two input numbers and prints the result. It ensures that there are no additional characters present in the output.

#### Prime.asm:
This assembly program checks whether a given input number is a prime number. If the number is prime, it prints "Yes"; otherwise, it prints "No". The solution is case-sensitive and ensures no additional characters are printed.

#### QuickSort.asm:
This assembly program implements the Quick Sort algorithm recursively to sort an array of integers. It takes an array of length \( n \) as input, where \( 0 \leq n \leq 10^6 \), and prints the sorted array. The algorithm employs stack for parameter passing.

#### BinarySearch.asm:
This assembly program utilizes the Binary Search algorithm to find the smallest index of a given query in a sorted array. It handles multiple queries and prints the corresponding index or "NaN" if the query is not found. The implementation is recursive, and parameters are passed using stack.

#### minDifFp.asm:
This assembly program reads an integer \( n \) from the input. It then proceeds to read \( n \) floating-point numbers, each on a separate line. Afterward, it calculates the difference between all pairs of numbers and finds the minimum difference. Finally, it prints the two numbers corresponding to this minimum difference, ensuring that the first number printed is the one encountered earlier in the input. The precision of the numbers is maintained up to six decimal places.

#### LightImages.asm:
This assembly program brightens valid BMP files in a given directory. It reads the address of a directory and an integer \( n \), then brightens the BMP files in parallel using \( n \) threads. The brightened images are saved with their original names in a new directory called "edited_photo" within the same directory.

#### assembler.asm:
This assembly program acts as an assembler. It reads assembly instructions in each line from an input file and generates two output files. The first output file is a binary file containing the binary representation of the instructions without spaces. The second output file lists each assembly instruction alongside its hexadecimal representation, separated by a space. For example: `4889d8 mov rax,rbx`.
