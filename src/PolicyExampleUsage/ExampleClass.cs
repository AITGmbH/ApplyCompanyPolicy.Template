namespace PolicyExampleUsage
{
#pragma warning disable 67 // Event never invoked.
#pragma warning disable 169 // Unused variable
#pragma warning disable 414 // Unused variable

    #region

    using System;
    using System.Diagnostics.CodeAnalysis;

    #endregion

    /// <summary>
    /// This class ensures that we can have 0 warnings -> we have no conflicts between StyleCop and ReSharper (naming
    /// style).
    /// </summary>
    public class ExampleClass
    {
        /// <summary>
        /// Some Documentation.
        /// </summary>
        public const string ConstPublicReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation.
        /// </summary>
        public static readonly string StaticPublicReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation
        /// </summary>
        [SuppressMessage("StyleCop.CSharp.MaintainabilityRules", "SA1401:FieldsMustBePrivate", Justification = "Reviewed.")]
        [SuppressMessage("Microsoft.Usage", "CA2211:NonConstantFieldsShouldNotBeVisible", Justification = "Reviewed.")]
        public static string StaticPublicVariable = "test";

        /// <summary>
        /// Some Documentation.
        /// </summary>
        [SuppressMessage("StyleCop.CSharp.MaintainabilityRules", "SA1401:FieldsMustBePrivate", Justification = "Reviewed.")]
        [SuppressMessage("Microsoft.Design", "CA1051:DoNotDeclareVisibleInstanceFields", Justification = "Reviewed.")]
        public readonly string PublicReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation
        /// </summary>
        [SuppressMessage("StyleCop.CSharp.MaintainabilityRules", "SA1401:FieldsMustBePrivate", Justification = "Reviewed.")]
        [SuppressMessage("Microsoft.Design", "CA1051:DoNotDeclareVisibleInstanceFields", Justification = "Reviewed.")]
        public string PublicVariable = "test";

        /// <summary>
        /// Some Documentation.
        /// </summary>
        [SuppressMessage("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields", Justification = "Reviewed.")]
        private const string ConstPrivateReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation.
        /// </summary>
        [SuppressMessage("Microsoft.Performance", "CA1802:UseLiteralsWhereAppropriate", Justification = "Reviewed.")]
        private static readonly string StaticPrivateReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation
        /// </summary>
        [SuppressMessage("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields", Justification = "Reviewed.")]
        private static string _staticPrivateVariable = "test";

        /// <summary>
        /// Some Documentation.
        /// </summary>
        private readonly string _privateReadOnlyVariable = "test";

        /// <summary>
        /// Some Documentation
        /// </summary>
        private string _privateVariable = "test";

        /// <summary>
        /// Initializes a new instance of the <see cref="T:System.Object" /> class.
        /// </summary>
        public ExampleClass(string publicReadOnlyVariable, string publicVariable, string privateReadOnlyVariable, string privateVariable)
            : this(privateReadOnlyVariable, privateVariable)
        {
            PublicReadOnlyVariable = publicReadOnlyVariable;
            PublicVariable = publicVariable;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="T:System.Object" /> class.
        /// </summary>
        protected ExampleClass(string privateReadOnlyVariable)
        {
            _privateReadOnlyVariable = privateReadOnlyVariable + _privateReadOnlyVariable;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="T:System.Object" /> class.
        /// </summary>
        private ExampleClass(string privateReadOnlyVariable, string privateVariable)
            : this(privateReadOnlyVariable)
        {
            _privateVariable = privateVariable;
        }

        /// <summary>
        /// Some Documentation.
        /// </summary>
        public event EventHandler SimplePublicEvent;

        /// <summary>
        /// Some Documentation.
        /// </summary>
        private event EventHandler SimplePrivateEvent;

        /// <summary>
        /// More documentation.
        /// </summary>
        public string MyProperty
        {
            get
            {
                return _privateVariable + "test";
            }
            set
            {
                Console.WriteLine(value);
            }
        }

        /// <summary>
        /// More documentation.
        /// </summary>
        [SuppressMessage("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode", Justification = "Reviewed.")]
        [SuppressMessage("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode", Justification = "Reviewed.")]
        private string MyPrivateProperty
        {
            get
            {
                return _privateVariable + "test";
            }
            set
            {
                Console.WriteLine(value);
            }
        }

        /// <summary>
        /// Some documentation.
        /// </summary>
        /// <returns></returns>
        public static string StaticPrivateMethod()
        {
            return StaticPrivateReadOnlyVariable;
        }

        /// <summary>
        /// Some documentation.
        /// </summary>
        /// <param name="data"></param>
        public static void StaticPublicMethod(string data)
        {
            StaticPublicVariable = data;
        }

        /// <summary>
        /// Some Documentation.
        /// </summary>
        /// <param name="data"></param>
        public void PublicMethod(string data)
        {
            _privateVariable = data;
        }

        [SuppressMessage("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode", Justification = "Reviewed.")]
        private string PrivateMethod()
        {
            return _privateReadOnlyVariable + _privateVariable;
        }
    }
}