﻿using System.CodeDom.Compiler;
using System.Diagnostics.CodeAnalysis;

namespace ClassLibrary
{
    public class Class
    {
        [ExcludeFromCodeCoverage]
        public bool Method_Excluded_From_Code_Coverage()
        {
            return true;
        }

        [CustomExcludeFromCodeCoverage]
        public bool Method_Excluded_From_Code_Coverage_By_Custom_Attribute()
        {
            return true;
        }

        public bool Method_Not_Covered()
        {
            return true;
        }

        [GeneratedCode("Test", "1")]
        public bool Method_Code_Generated_By_Tool()
        {
            return true;
        }

        public bool Method_Covered_By_MSpec()
        {
            return true;
        }

        public bool Method_Covered_By_NUnit()
        {
            return true;
        }

        public bool Method_Covered_By_xUnit()
        {
            return true;
        }
    }
}
