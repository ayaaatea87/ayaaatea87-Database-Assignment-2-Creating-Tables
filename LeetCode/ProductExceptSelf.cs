using System;


public int[] ProductExceptSelfWithPrefixSuffix(int[] nums)
{
    int n = nums.Length;

    int[] prefix = new int[n];
    int[] suffix = new int[n];
    int[] result = new int[n];

    // Step 1: Calculate Prefix
    prefix[0] = 1;

    for (int i = 1; i < n; i++)
    {
        prefix[i] = prefix[i - 1] * nums[i - 1];
    }

    // Step 2: Calculate Suffix
    suffix[n - 1] = 1;

    for (int i = n - 2; i >= 0; i--)
    {
        suffix[i] = suffix[i + 1] * nums[i + 1];
    }

    // Step 3: Calculate Result
    for (int i = 0; i < n; i++)
    {
        result[i] = prefix[i] * suffix[i];
    }

    return result;
}




public int[] ProductExceptSelf(int[] nums)
{
    int n = nums.Length;
    int[] result = new int[n];

    // Step 1: Calculate Prefix
    int prefix = 1;

    for (int i = 0; i < n; i++)
    {
        result[i] = prefix;
        prefix *= nums[i];
    }

    // Step 2: Calculate Suffix
    int suffix = 1;

    for (int i = n - 1; i >= 0; i--)
    {
        result[i] *= suffix;
        suffix *= nums[i];
    }

    return result;
}

