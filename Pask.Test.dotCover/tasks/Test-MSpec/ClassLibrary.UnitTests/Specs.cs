using System;
using Machine.Fakes;
using Machine.Specifications;

namespace ClassLibrary.UnitTests
{
    [Tags("tag1")]
    [Subject(typeof(string))]
    public class StringSpec : WithSubject<String>
    {
        It should_be_true = () => true.ShouldBeTrue();

        Because of = () => { };

        Establish context = () => { };
    }

    [Subject(typeof(object))]
    public class ObjectSpec : WithSubject<object>
    {
        It should_be_true = () => true.ShouldBeTrue();

        Because of = () => { };

        Establish context = () => { };
    }

    [Tags("tag2")]
    [Subject(typeof(int))]
    public class IntSpec : WithSubject<System.Object>
    {
        It should_be_true = () => true.ShouldBeTrue();

        Because of = () => { };

        Establish context = () => { };
    }
}
