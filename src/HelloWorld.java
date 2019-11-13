class HelloWorld {
  static {
    System.loadLibrary("HelloWorld");
  }

  private native void print();

  // entry point
  public static void main(String[] args) {
      new HelloWorld().print();
  }
}
