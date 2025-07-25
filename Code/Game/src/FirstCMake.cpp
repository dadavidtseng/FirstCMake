#include <cstdio>
#include <cstring>
#include <vector>
#include <ranges>  // C++20 ranges
#include "../include/Utils.h"
// #include "Utils.h"

int main() {
    // 顯示歡迎訊息
    Utils::ShowWelcome("FirstCMake");
    
    // 展示字串處理功能
    char name[100];
    printf("\nPlease enter your name: ");
    
    if (fgets(name, sizeof(name), stdin) != nullptr) {
        // 移除換行符號
        size_t len = strlen(name);
        if (len > 0 && name[len-1] == '\n') {
            name[len-1] = '\0';
        }
        
        if (strlen(name) > 0) {
            std::string nameStr(name);
            std::string upperName = Utils::ToUpper(nameStr);
            
            printf("Hello, %s!\n", name);
            printf("Uppercase form: %s\n", upperName.c_str());
        }
    }
    
    // 展示 C++20 concepts 的數學計算功能
    printf("\nMath tests with C++20 concepts:\n");
    printf("Integer: 5 + 3 = %d\n", Utils::Add(5, 3));
    printf("Float: 2.5 + 1.7 = %.2f\n", Utils::Add(2.5f, 1.7f));
    printf("Double: 10.25 + 5.75 = %.2f\n", Utils::Add(10.25, 5.75));
    
    // 使用 C++20 ranges 展示功能列表
    auto features = Utils::GetFeatures();
    Utils::PrintRange(features, "Project Features");
    
    // C++20 ranges 範例：過濾包含 "C++" 的功能
    printf("\nC++ related features:\n");
    auto cppFeatures = features 
        | std::views::filter([](const std::string& feature) {
            return feature.find("C++") != std::string::npos;
        });
    
    int index = 1;
    for (const auto& feature : cppFeatures) {
        printf("%d. %s\n", index++, feature.c_str());
    }
    
    printf("\nC++20 CMake multi-file build successful!\n");
    printf("Press Enter to exit...");
    getchar();
    
    return 0;
}