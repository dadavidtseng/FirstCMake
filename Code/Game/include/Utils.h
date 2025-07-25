#pragma once
#include <string>
#include <vector>
#include <concepts>  // C++20 concepts
#include <format>    // C++20 formatting (需要較新的編譯器)

// 實用函式宣告 - 使用 PascalCase 命名
namespace Utils {
    // C++20 concept 範例
    template<typename T>
    concept Numeric = std::integral<T> || std::floating_point<T>;

    // 計算兩個數字的和（使用 concept）
    template<Numeric T>
    T Add(T a, T b);

    // 將字串轉換為大寫
    std::string ToUpper(const std::string& str);

    // 顯示歡迎訊息
    void ShowWelcome(const std::string& projectName);

    // 取得可用的功能列表
    std::vector<std::string> GetFeatures();

    // C++20 新功能：使用 ranges 和 concepts
    template<std::ranges::range R>
    void PrintRange(const R& range, const std::string& title);

    // 格式化字串（C++20 std::format 的包裝）
    template<typename... Args>
    std::string FormatString(const std::string& format, Args&&... args);
}