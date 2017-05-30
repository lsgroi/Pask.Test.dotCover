using NUnit.Framework;

namespace ClassLibrary.IntegrationTests
{
    [TestFixture]
    public class NUnitTests
    {
        [Test]
        public void Test_3()
        {
            Assert.True(true);
        }

        [Test]
        public void Test_4()
        {
            Assert.True(new Class().Method_Covered_By_NUnit());
        }
    }
}
