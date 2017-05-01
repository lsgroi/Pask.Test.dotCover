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

    [Subject(typeof(Class))]
    public class ClassSpec : WithSubject<Class>
    {
        It should_be_true = () => result.ShouldBeTrue();

        Because of = () => result = Subject.Method_Covered();

        Establish context = () => { };

        static bool result;
    }
}
