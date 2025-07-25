//----------------------------------------------------------------------------------------------------
// Utils.h
//----------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------
#pragma once
#include <string>
#include <vector>
#include <concepts>  // C++20 concepts

//----------------------------------------------------------------------------------------------------
// 實用函式宣告 - 使用 PascalCase 命名
namespace Utils
{
    // C++20 concept 範例
    template <typename T>
    concept Numeric = std::integral<T> || std::floating_point<T>;

    // 計算兩個數字的和（使用 concept）
    template <Numeric T>
    T Add(T a, T b);

    // 將字串轉換為大寫
    std::string ToUpper(const std::string& str);

    // 顯示歡迎訊息
    void ShowWelcome(const std::string& projectName);

    // 取得可用的功能列表
    std::vector<std::string> GetFeatures();

    // 印出範圍內容（使用具體類型而非 ranges template）
    void PrintRange(const std::vector<std::string>& range, const std::string& title);

    // 格式化字串（簡化版本）
    template <typename... Args>
    std::string FormatString(const std::string& format, Args&&... args);
}