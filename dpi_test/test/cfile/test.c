#include <stdio.h>
#include <stdlib.h>
#include <svdpi.h>
#include "test.h"

#include <svdpi.h>
#include "test.h"

void c_function(){
    printf("c function is finished\n");
}

void c_trans(tx_packet_t *tx_packet){
    printf("tx: addr = %d, data = %d\n", tx_packet->addr, tx_packet->data);
}

void cpp_long_vector(svBitVecVal* vector){
    printf("vector is:");
    for (int i = 0; i < 10; i++){
        printf( "%x", *(vector+i));
    }
    printf("\n");
}