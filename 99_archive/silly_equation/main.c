int __fastcall main(int argc, const char **argv, const char **envp)
{
  double v4; // [rsp+8h] [rbp-18h] BYREF
  double v5; // [rsp+10h] [rbp-10h]
  unsigned __int64 v6; // [rsp+18h] [rbp-8h]

  v6 = __readfsqword(0x28u);
  setvbuf(stdin, 0, 2, 0);
  setvbuf(_bss_start, 0, 2, 0);
  v4 = 0.0;
  v5 = 0.0 + 0.1 + 0.2;
  printf("Input password : ");
  __isoc99_scanf("%llu", &v4);
  if ( v4 == v5 )
  {
    puts("Correct!");
    get_flag();
  }
  else
  {
    puts("Wrong...");
  }
  return 0;
}