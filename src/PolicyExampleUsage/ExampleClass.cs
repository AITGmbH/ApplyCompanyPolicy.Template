using System;
using System.Diagnostics.CodeAnalysis;
// ReSharper disable UnusedMember.Local
// ReSharper disable EventNeverSubscribedTo.Local
#pragma warning disable 67 // Event never invoked.

#pragma warning disable 169 // Unused variable
#pragma warning disable 414 // Unused variable

namespace PolicyExampleUsage
{
    /// <summary>
    /// This class ensures that we can have 0 warnings -> we have no conflicts between StyleCop and ReSharper (naming style).
    /// </summary>
    public class ExampleClass
    {
        /// <summary>
        /// Some Documentation.
        /// </summary>
        public static readonly string StaticPublicReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation.
        /// </summary>
        public const string ConstPublicReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation
        /// </summary>
        [SuppressMessage("StyleCop.CSharp.MaintainabilityRules", "SA1401:FieldsMustBePrivate", Justification = "Reviewed.")]
        [SuppressMessage("Microsoft.Usage", "CA2211:NonConstantFieldsShouldNotBeVisible")]
        public static string StaticPublicVariable = "test";

        /// <summary>
        /// Some Documentation.
        /// </summary>
        [SuppressMessage("StyleCop.CSharp.MaintainabilityRules", "SA1401:FieldsMustBePrivate", Justification = "Reviewed.")]
        [SuppressMessage("Microsoft.Design", "CA1051:DoNotDeclareVisibleInstanceFields")]
        public readonly string PublicReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation
        /// </summary>
        [SuppressMessage("StyleCop.CSharp.MaintainabilityRules", "SA1401:FieldsMustBePrivate", Justification = "Reviewed.")]
        [SuppressMessage("Microsoft.Design", "CA1051:DoNotDeclareVisibleInstanceFields")]
        public string PublicVariable = "test";

        /// <summary>
        /// Some Documentation.
        /// </summary>
        public event EventHandler SimplePublicEvent;

        /// <summary>
        /// Some Documentation.
        /// </summary>
        [SuppressMessage("Microsoft.Performance", "CA1802:UseLiteralsWhereAppropriate")]
        [SuppressMessage("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        private static readonly string StaticPrivateReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation.
        /// </summary>
        [SuppressMessage("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        private const string ConstPrivateReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation
        /// </summary>
        [SuppressMessage("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        private static string staticPrivateVariable = "test";

        /// <summary>
        /// Some Documentation.
        /// </summary>
        [SuppressMessage("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        private readonly string privateReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation
        /// </summary>
        [SuppressMessage("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        private string privateVariable = "test";


        /// <summary>
        /// Some Documentation.
        /// </summary>
        private event EventHandler SimplePrivateEvent;
    }
}
