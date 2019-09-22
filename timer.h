#ifndef OPEN_SOURCE_TIMER_IMPL_H
#define OPEN_SOURCE_TIMER_IMPL_H

#include <iostream>
#include <chrono>

class Timer
{
public:
    Timer() : beg_(clock_::now()) {}
    void reset() { beg_ = clock_::now(); }
    double elapsed() const { 
        return std::chrono::duration_cast<second_>
            (clock_::now() - beg_).count(); }

    void cout_elapsed(const std::string &name) {
        double e_ = elapsed();
        std::cout << "[" << name << "]" << " elapsed: " << e_ << " sec" << std::endl;        
    }

private:
    typedef std::chrono::high_resolution_clock clock_;
    typedef std::chrono::duration<double, std::ratio<1> > second_;
    std::chrono::time_point<clock_> beg_;
};

#endif