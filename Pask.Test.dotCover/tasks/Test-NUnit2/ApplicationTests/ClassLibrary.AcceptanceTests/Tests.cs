using NUnit.Framework;

namespace ClassLibrary.AcceptanceTests
{
    [TestFixture]
    public class Tests
    {
        [Test]
        public void Test_3()
        {
            Assert.True(true);
        }

        [Test]
        [Category("category2")]
        public void Test_4()
        {
            Assert.True(true);
        }
    }
}
