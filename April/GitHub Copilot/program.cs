int addPrimeNumbersInNumericList(List<int> numbers)
{
    int sum = 0;
    foreach (int number in numbers)
    {
        if (isPrime(number))
        {
            sum += number;
        }
    }
    return sum;
}

bool isPrime(int number)
{
    if (number <= 1)
    {
        return false;
    }
    for (int i = 2; i <= Math.Sqrt(number); i++)
    {
        if (number % i == 0)
        {
            return false;
        }
    }

    return true;
}

// create a list of 100 random number between 1 and 1000
List<int> numbers = new List<int>();
Random random = new Random();
for (int i = 0; i < 100; i++)
{
    numbers.Add(random.Next(1, 1000));
}

int sum = addPrimeNumbersInNumericList(numbers);
Console.WriteLine(sum);
Console.WriteLine("The sum of prime numbers in the list is: " + sum);