using System;
using System.Text;
using Machine.Fakes;
using Machine.Specifications;

namespace ClassLibrary.UnitTests
{
    [Subject(typeof(String))]
    public class StringSpec : WithSubject<String>
    {
        It should_be_true = () => true.ShouldBeTrue();

        Because of = () => { };

        Establish context = () => { };
    }

    [Subject(typeof(Object))]
    public class ObjectSpec : WithSubject<Object>
    {
        It should_be_true = () => true.ShouldBeTrue();

        Because of = () => { };

        Establish context = () => { };
    }

    [Subject(typeof(StringBuilder))]
    public class StringBuilderSpec : WithSubject<StringBuilder>
    {
        It should_be_true = () => true.ShouldBeTrue();

        Because of = () => { };

        Establish context = () => { };
    }
}
