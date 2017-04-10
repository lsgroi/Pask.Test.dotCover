using NUnit.Framework;

namespace ClassLibrary.UnitTests
{
    [TestFixture]
    public class Tests
    {
        [Test]
        [Category("category1")]
        public void Test_1()
        {
            Assert.True(true);
        }

        [Test]
        [Category("category2")]
        public void Test_2()
        {
            Assert.True(true);
        }
    }
}
