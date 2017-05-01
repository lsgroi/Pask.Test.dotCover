using NUnit.Framework;

namespace ClassLibrary.IntegrationTests
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

        [Test]
        public void Test_5()
        {
            Assert.True(new Class().Method_Covered());
        }
    }
}
