using System.CodeDom.Compiler;
using System.Diagnostics.CodeAnalysis;

namespace ClassLibrary
{
    public class Class
    {
        [ExcludeFromCodeCoverage]
        public bool Method1()
        {
            return true;
        }

        [CustomExcludeFromCodeCoverage]
        public bool Method2()
        {
            return true;
        }

        public bool Method3()
        {
            return true;
        }

        [GeneratedCode("Test", "1")]
        public bool Method4()
        {
            return true;
        }
    }
}
