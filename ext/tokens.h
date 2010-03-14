enum token_type { BOX, GLUE, PENALTY };

struct box {
  enum token_type type;
  double width;
  char * content;
};

struct glue {
  enum token_type type;
  double width;
  double stretch;
  double shrink;
};

struct penalty {
  enum token_type type;
  double width;
  double penalty;
  int flagged;
};

typedef union {
  struct box box;
  struct glue glue;
  struct penalty penalty;
} token;

