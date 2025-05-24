#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <cmath>
#include <filesystem>

// Boost includes
#include <boost/math/special_functions/gamma.hpp>
#include <boost/algorithm/string.hpp>

// SQLite include
#include <sqlite3.h>

// LZMA/XZ includes
#include <lzma.h>

// Native C++ implementations of mathematical functions
int64_t fibonacci(int32_t n) {
    if (n <= 1) {
        return n;
    }
    
    int64_t a = 0;
    int64_t b = 1;
    
    for (int i = 1; i < n; i++) {
        int64_t temp = a + b;
        a = b;
        b = temp;
    }
    
    return b;
}

int64_t factorial(int32_t n) {
    if (n <= 1) {
        return 1;
    }
    
    int64_t result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    
    return result;
}

// Helper function to compress a file using XZ
bool compress_file(const std::string& input_path, const std::string& output_path) {
    std::ifstream input(input_path, std::ios::binary);
    std::ofstream output(output_path, std::ios::binary);
    
    if (!input || !output) {
        std::cerr << "Error opening files for compression" << std::endl;
        return false;
    }
    
    lzma_stream strm = LZMA_STREAM_INIT;
    
    if (lzma_easy_encoder(&strm, 9, LZMA_CHECK_CRC64) != LZMA_OK) {
        std::cerr << "Error initializing LZMA encoder" << std::endl;
        return false;
    }
    
    const size_t BUFFER_SIZE = 4096;
    uint8_t in_buf[BUFFER_SIZE];
    uint8_t out_buf[BUFFER_SIZE];
    
    strm.next_out = out_buf;
    strm.avail_out = BUFFER_SIZE;
    
    lzma_action action = LZMA_RUN;
    
    while (true) {
        if (strm.avail_in == 0 && input) {
            input.read(reinterpret_cast<char*>(in_buf), BUFFER_SIZE);
            strm.next_in = in_buf;
            strm.avail_in = input.gcount();
            
            if (input.eof()) {
                action = LZMA_FINISH;
            }
        }
        
        lzma_ret ret = lzma_code(&strm, action);
        
        if (strm.avail_out == 0 || ret == LZMA_STREAM_END) {
            size_t write_size = BUFFER_SIZE - strm.avail_out;
            output.write(reinterpret_cast<char*>(out_buf), write_size);
            
            strm.next_out = out_buf;
            strm.avail_out = BUFFER_SIZE;
        }
        
        if (ret == LZMA_STREAM_END)
            break;
        
        if (ret != LZMA_OK) {
            std::cerr << "Error while encoding: " << ret << std::endl;
            lzma_end(&strm);
            return false;
        }
    }
    
    lzma_end(&strm);
    return true;
}

int main() {
    std::cout << "Integration Demo: C++ with Boost, SQLite, and XZ" << std::endl;
    std::cout << "------------------------------------------------" << std::endl;
    
    // Part 1: Calculate Fibonacci and factorial values using C++
    std::cout << "\n1. Calculating mathematical sequences:" << std::endl;
    
    int n = 10;
    int64_t fib_result = fibonacci(n);
    int64_t fact_result = factorial(n);
    
    std::cout << "  Fibonacci(" << n << ") = " << fib_result << std::endl;
    std::cout << "  Factorial(" << n << ") = " << fact_result << std::endl;
    
    // Part 2: Use Boost for some calculations
    std::cout << "\n2. Using Boost libraries:" << std::endl;
    
    // Use Boost.Math for gamma function
    double gamma_result = boost::math::tgamma(5.5);
    std::cout << "  Gamma(5.5) = " << gamma_result << std::endl;
    
    // Use Boost.Algorithm for string manipulation
    std::string text = "hello,world,boost,example";
    std::vector<std::string> parts;
    boost::split(parts, text, boost::is_any_of(","));
    
    std::cout << "  Split string: ";
    for (const auto& part : parts) {
        std::cout << "'" << part << "' ";
    }
    std::cout << std::endl;
    
    // Part 3: Use SQLite to store calculations
    std::cout << "\n3. Using SQLite for data storage:" << std::endl;
    
    const std::string db_path = "calculations.db";
    sqlite3* db;
    int rc = sqlite3_open(db_path.c_str(), &db);
    
    if (rc) {
        std::cerr << "  Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return 1;
    }
    
    // Create a table
    const char* create_table_sql = "CREATE TABLE IF NOT EXISTS calculations ("
                                    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                    "type TEXT NOT NULL,"
                                    "input INTEGER NOT NULL,"
                                    "result INTEGER NOT NULL)";
                                    
    char* err_msg = nullptr;
    rc = sqlite3_exec(db, create_table_sql, nullptr, nullptr, &err_msg);
    
    if (rc != SQLITE_OK) {
        std::cerr << "  SQL error: " << err_msg << std::endl;
        sqlite3_free(err_msg);
        sqlite3_close(db);
        return 1;
    }
    
    // Store calculations
    for (int i = 1; i <= 10; i++) {
        int64_t fib = fibonacci(i);
        int64_t fact = factorial(i);
        
        std::string sql_fib = "INSERT INTO calculations (type, input, result) VALUES ('fibonacci', " + 
                                std::to_string(i) + ", " + std::to_string(fib) + ")";
                                
        std::string sql_fact = "INSERT INTO calculations (type, input, result) VALUES ('factorial', " + 
                                std::to_string(i) + ", " + std::to_string(fact) + ")";
        
        rc = sqlite3_exec(db, sql_fib.c_str(), nullptr, nullptr, &err_msg);
        if (rc != SQLITE_OK) {
            std::cerr << "  SQL error: " << err_msg << std::endl;
            sqlite3_free(err_msg);
        }
        
        rc = sqlite3_exec(db, sql_fact.c_str(), nullptr, nullptr, &err_msg);
        if (rc != SQLITE_OK) {
            std::cerr << "  SQL error: " << err_msg << std::endl;
            sqlite3_free(err_msg);
        }
    }
    
    // Query and display some data
    std::cout << "  Stored calculations in SQLite database:" << std::endl;
    
    const char* query_sql = "SELECT type, input, result FROM calculations LIMIT 5";
    
    auto callback = [](void*, int count, char** data, char** columns) -> int {
        for (int i = 0; i < count; i++) {
            std::cout << "    " << columns[i] << ": " << (data[i] ? data[i] : "NULL") << "  ";
        }
        std::cout << std::endl;
        return 0;
    };
    
    rc = sqlite3_exec(db, query_sql, callback, nullptr, &err_msg);
    
    if (rc != SQLITE_OK) {
        std::cerr << "  SQL error: " << err_msg << std::endl;
        sqlite3_free(err_msg);
    }
    
    sqlite3_close(db);
    std::cout << "  Database operations completed and closed." << std::endl;
    
    // Part 4: Use XZ to compress the database file
    std::cout << "\n4. Using XZ for compression:" << std::endl;
    
    const std::string compressed_path = db_path + ".xz";
    
    std::cout << "  Compressing database file..." << std::endl;
    if (compress_file(db_path, compressed_path)) {
        auto original_size = std::filesystem::file_size(db_path);
        auto compressed_size = std::filesystem::file_size(compressed_path);
        
        std::cout << "  Original size: " << original_size << " bytes" << std::endl;
        std::cout << "  Compressed size: " << compressed_size << " bytes" << std::endl;
        std::cout << "  Compression ratio: " << (float)compressed_size / original_size * 100.0f << "%" << std::endl;
    } else {
        std::cerr << "  Compression failed" << std::endl;
    }
    
    std::cout << "\nDemo completed successfully!" << std::endl;
    
    return 0;
}