using Xunit;

namespace ClassLibrary.AcceptanceTests
{
    public class xUnitTests
    {
        [Fact]
        public void Test_3()
        {
            Assert.True(true);
        }

        [Fact]
        public void Test_4()
        {
            Assert.True(new Class().Method_Covered_By_xUnit());
        }
    }
}
