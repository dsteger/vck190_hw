
#include "ndt.h"

template <typename WIDTH_T, int SIZE>
void ndt(
    WIDTH_T *in,
    WIDTH_T *out) {

    for (int i = 0; i < SIZE; i++) {
        out[i] = in[i];
    }
}

void ndt_accel(
  int size,
  uint32_t *in,
  uint32_t *out) {
#pragma HLS INTERFACE s_axilite port = size
#pragma HLS INTERFACE m_axi port = in offset = slave bundle = ndt_in
#pragma HLS INTERFACE m_axi port = out offset = slave bundle = ndt_out
#pragma HLS INTERFACE s_axilite port = return

    ndt <uint32_t, 10> (in, out);
}
