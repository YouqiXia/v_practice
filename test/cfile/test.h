#ifndef TESTHEAD
#define TESTHEAD

typedef struct {
    int addr;
    int data;
}tx_packet_t;

void c_function();
void c_trans(tx_packet_t *tx_packet);

#endif