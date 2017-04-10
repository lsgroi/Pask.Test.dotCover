using System;
using Machine.Fakes;
using Machine.Specifications;

namespace ClassLibrary.AcceptanceTests
{
    [Tags("tag1")]
    [Subject(typeof(string))]
    public class StringSpec : WithSubject<String>
    {
        It should_be_true = () => true.ShouldBeTrue();

        Because of = () => { };

        Establish context = () => { };
    }
}
