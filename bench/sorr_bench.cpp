// bench/sort_bench.cpp
#include <algorithm>
#include <chrono>
#include <iostream>
#include <vector>

int main(int argc, char** argv) {
    std::ios::sync_with_stdio(false);
    std::cin.tie(nullptr);

    int n;
    if (!(std::cin >> n)) {
        std::cerr << "failed to read n\n";
        return 2;
    }

    std::vector<int> v(n);
    for (int i = 0; i < n; ++i) {
        if (!(std::cin >> v[i])) {
            std::cerr << "failed to read value at index " << i << "\n";
            return 3;
        }
    }

    std::sort(v.begin(), v.end());

    // Small deterministic output so stdout is functional, not noisy.
    std::cout << v.front() << " " << v.back() << "\n";
    return 0;
}
