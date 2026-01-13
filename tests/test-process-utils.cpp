#include <gtest/gtest.h>
#include "../src/process-utils.hpp"

// Helper to assist testing internal logic if needed, 
// but DeDuplicateCaptureList logic is pure function.

TEST(ProcessUtilsTest, DeDuplicateSimple) {
    std::set<DWORD> pids = {};
    auto result = ProcessUtils::DeDuplicateCaptureList(pids);
    EXPECT_TRUE(result.empty());
}
