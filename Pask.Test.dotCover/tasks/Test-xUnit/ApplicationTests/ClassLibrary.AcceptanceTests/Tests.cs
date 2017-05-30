
using Xunit;

namespace ClassLibrary.AcceptanceTests
{
    public class Tests
    {
        [Fact]
        public void Test_3()
        {
            Assert.True(true);
        }

        [Fact]
        [Trait("Category", "category2")]
        public void Test_4()
        {
            Assert.True(true);
        }

        [Fact]
        public void Test_5()
        {
            Assert.True(new Class().Method_Covered());
        }
    }
}
