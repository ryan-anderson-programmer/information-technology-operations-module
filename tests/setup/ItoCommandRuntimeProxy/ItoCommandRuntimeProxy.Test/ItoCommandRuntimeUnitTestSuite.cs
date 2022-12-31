using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ItoCommandRuntimeProxy.Test
{
    /// <summary>
    /// This is a suite of unit tests for testing the ItoCommandRuntimeProxy class.
    /// </summary>
    [TestClass]
    public class ItoCommandRuntimeProxyUnitTestSuite
    {
        private const string Query = "Query";
        private const string Caption = "Caption";
        private const string Action = "Action";
        private const string Target = "Target";

        private ItoCommandRuntimeProxy itoCommandRuntimeProxy;

        [TestInitialize]
        public void InitializeTests()
        {
            itoCommandRuntimeProxy = new ItoCommandRuntimeProxy(); // Arrange.
        }

        [TestMethod]
        public void ShouldContinueThrowsArgumentNullExceptionWhenQueryIsNull()
        {
            void actual() => itoCommandRuntimeProxy.ShouldContinue(null, Caption); // Act.

            Assert.ThrowsException<ArgumentNullException>(actual); // Assert.
        }

        [TestMethod]
        public void ShouldContinueThrowsArgumentNullExceptionWhenCaptionIsNull()
        {
            void actual() => itoCommandRuntimeProxy.ShouldContinue(Query, null); // Act.

            Assert.ThrowsException<ArgumentNullException>(actual); // Assert.
        }

        [TestMethod]
        public void ShouldContinueReturnsTrue()
        {
            var actual = itoCommandRuntimeProxy.ShouldContinue(Query, Caption); // Act.

            Assert.IsTrue(actual); // Assert.
        }

        [TestMethod]
        public void ShouldProcessThrowsArgumentNullExceptionWhenTargetIsNull()
        {
            void actual() => itoCommandRuntimeProxy.ShouldProcess(null, Action); // Act.

            Assert.ThrowsException<ArgumentNullException>(actual); // Assert.
        }

        [TestMethod]
        public void ShouldProcessThrowsArgumentNullExceptionWhenActionIsNull()
        {
            void actual() => itoCommandRuntimeProxy.ShouldProcess(Target, null); // Act.

            Assert.ThrowsException<ArgumentNullException>(actual); // Assert.
        }

        [TestMethod]
        public void ShouldProcessReturnsTrue()
        {
            var actual = itoCommandRuntimeProxy.ShouldProcess(Target, Action); // Act.

            Assert.IsTrue(actual); // Assert.
        }
    }
}
