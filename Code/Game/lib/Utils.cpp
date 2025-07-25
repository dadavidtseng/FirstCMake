//----------------------------------------------------------------------------------------------------
// Utils.cpp
//----------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------
#include "../include/Utils.h"
// #include "Utils.h"
#include <cstdio>
#include <algorithm>
#include <cctype>
// #include <ranges>    // C++20 ranges - 移除這行，因為跨平台相容性問題

//----------------------------------------------------------------------------------------------------
namespace Utils
{
    // 使用 concept 的模板實作
    template <Numeric T>
    T Add(T a, T b)
    {
        return a + b;
    }

    // 明確實例化常用類型
    template int    Add<int>(int a, int b);
    template double Add<double>(double a, double b);
    template float  Add<float>(float a, float b);

    std::string ToUpper(const std::string& str)
    {
        std::string result = str;
        // 改用傳統的 std::transform（更好的跨平台相容性）
        std::transform(result.begin(), result.end(), result.begin(),
                      [](unsigned char c) { return std::toupper(c); });
        return result;
    }

    void ShowWelcome(const std::string& projectName)
    {
        printf("================================\n");
        printf("  Welcome to %s Project\n", projectName.c_str());
        printf("  This is a C++20 CMake example\n");
        printf("================================\n");
    }

    std::vector<std::string> GetFeatures()
    {
        return {
            "C++20 standard support",
            "Concepts and constraints",
            "Cross-platform compatibility",  // 改了這行，移除 "Ranges library usage"
            "PascalCase naming convention",
            "Advanced CMake configuration",
            "Template specialization",
            "Modern C++ best practices"
        };
    }

    // 改用傳統方式的函式（移除 ranges template）
    void PrintRange(const std::vector<std::string>& range, const std::string& title)
    {
        printf("\n%s:\n", title.c_str());
        int index = 1;
        for (const auto& item : range)
        {
            printf("%d. %s\n", index++, item.c_str());
        }
    }

    // 簡化版的格式化函式
    template <typename... Args>
    std::string FormatString(const std::string& format, Args&&... args)
    {
        // 這裡使用傳統方式，因為 std::format 支援可能不完整
        // 在實際專案中可以用 fmt 函式庫
        return format; // 簡化實作
    }

    // 明確實例化
    template std::string FormatString<>(const std::string& format);
}