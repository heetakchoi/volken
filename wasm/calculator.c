#include <stdio.h>
#include <emscripten/emscripten.h>

int main(){
  printf("계산기가 로딩되었습니다.\n");
  return 0;
}

EMSCRIPTEN_KEEPALIVE double plus(double left, double right){
  return left + right;
}
EMSCRIPTEN_KEEPALIVE double minus(double left, double right){
  return left - right;
}
EMSCRIPTEN_KEEPALIVE double multiply(double left, double right){
  return left * right;
}
EMSCRIPTEN_KEEPALIVE double divide(double left, double right){
  return left / right;
}

