class HelloWorld {
    // putting System.loadLibrary() here forces us
    // to mark this class to initialize at runtime
    // when building with native-image
    // https://github.com/oracle/graal/issues/1828
    //
    // static {
    //     System.loadLibrary("HelloWorld");
    // }

    private native void print();

    // entry point
    public static void main(String[] args) {

        // instead we System.loadLibrary() inside the execution path
        // to load the library file
        System.loadLibrary("HelloWorld");

        new HelloWorld().print();
    }

}
