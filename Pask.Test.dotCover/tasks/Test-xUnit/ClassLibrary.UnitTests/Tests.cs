
using Xunit;

namespace ClassLibrary.UnitTests
{
    public class Tests
    {
        [Fact]
        [Trait("Category", "category1")]
        public void Test_1()
        {
            Assert.True(true);
        }

        [Fact]
        [Trait("Category", "category2")]
        public void Test_2()
        {
            Assert.True(true);
        }
    }
}
