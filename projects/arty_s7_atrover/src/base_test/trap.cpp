extern "C" {
    void trap() {
        int cnt = 5;
        while(--cnt);
    }
}
