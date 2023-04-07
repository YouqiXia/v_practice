#include <stdio.h>
#include <stdlib.h>
#include <svdpi.h>
#include "test.h"

void c_function(){
    printf("c function is finished\n");
}

void c_trans(tx_packet_t *tx_packet){
    printf("tx: addr = %d, data = %d\n", tx_packet->addr, tx_packet->data);
}